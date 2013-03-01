{-
Copyright (C) 2013 Michael Fogus <me -at- fogus -dot- me>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}

module Parser (read', read_)
where
import Data.Complex
import Control.Monad.Error (liftM, throwError)
import Data.Array (Array (..), listArray)
import System.IO
import Numeric (readFloat)
import Data.Ratio
import Text.Parsec.Language
import Text.ParserCombinators.Parsec
import qualified Text.Parsec.Token as P
import Types
import Debug.Trace
import Helpers

-- The set of characters allowed within identifiers

symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

-- Language

langdef :: LanguageDef ()
langdef = emptyDef
        { P.commentStart   = "#|"
        , P.commentEnd     = "|#"
        , P.commentLine    = "--"
        , P.nestedComments = True
        , P.identStart     = letter <|> symbol
        , P.identLetter    = letter <|> digit <|> symbol
        , P.reservedNames  = []
        , P.caseSensitive  = True
        }

lexer      = P.makeTokenParser langdef
dot        = P.dot lexer
parens     = P.parens lexer
identifier = P.identifier lexer
ws         = P.whiteSpace lexer
lexeme     = P.lexeme lexer

-- ## Type parsers

escaped :: Parser Char
escaped = do char '\\'                               -- a backslash
             x <- oneOf "\\\"nrt"                    -- either backslash or doublequote
             return $ case x of                      -- return the escaped character
               '\\' -> x
               '"'  -> x
               'n'  -> '\n'
               'r'  -> '\r'
               't'  -> '\t'

parseString :: Parser LispVal
parseString = do char '"'
                 x <- many $ escaped <|> noneOf "\"\\"
                 char '"'
                 return $ String x

parseAtom :: Parser LispVal
parseAtom = do atom <- identifier
               if atom == "."
                  then pzero
                  else return $ Atom atom

parseBool :: Parser LispVal
parseBool = do string "#"
               ch <- oneOf "tf"
               return $ case ch of
                        't' -> Bool True
                        'f' -> Bool False
                        _   -> Bool False

parseInteger :: Parser LispVal
parseInteger = liftM (Number . read) $ many1 digit

-- TODO
parseHex :: Parser LispVal
parseHex = liftM (Number . read) $ many1 digit

parseIntegral :: Parser LispVal
parseIntegral = parseInteger <|>
                parseHex <?>
                "Unable to parse integer form"

parseFloat :: Parser LispVal
parseFloat = do x <- many1 digit
                char '.'
                y <- many1 digit
                return $ Float (fst.head$readFloat (x++"."++y))

parseRatio :: Parser LispVal
parseRatio = do x <- many1 digit
                char '/'
                y <- many1 digit
                return $ Ratio ((read x) % (read y))

toDouble :: LispVal -> Double
toDouble(Float f) = f
toDouble(Number n) = fromIntegral n

parseComplex :: Parser LispVal
parseComplex = do x <- (try parseFloat <|> parseIntegral)
                  char '+'
                  y <- (try parseFloat <|> parseIntegral)
                  char 'i'
                  return $ Complex (toDouble x :+ toDouble y)

parseList :: Parser LispVal
parseList = liftM List $ sepBy parse' spaces

-- add 'quote support
parseQuoted :: Parser LispVal
parseQuoted = do
   char '\''
   x <- parse'
   return $ List [Atom "quote", x]

parseExpr :: Parser LispVal
parseExpr = lexeme parseString
          <|> lexeme parseBool
          <|> try parseAtom
          <|> try (lexeme parseFloat)
          <|> try (lexeme parseRatio)
          <|> try (lexeme parseComplex)
          <|> try (lexeme parseIntegral)
          <|> parseQuoted
          <|> parseQuasiquote
          <|> try parseUnquoteSplicing
          <|> parseUnquote
          <|> parseVector
          <|> parseBlock
          <|> try (parens parseList)
          <?> "Form"

parse' :: Parser LispVal
parse' = do _ <- ws
            expr <- parseExpr
            return expr

readOrThrow :: Parser a -> String -> ThrowsError a
readOrThrow parser input = case parse parser "lisp" input of
    Left err -> throwError $ Parser err
    Right val -> return val


read' = readOrThrow parse'
read_ = readOrThrow (endBy parse' ws)

-- # quasiquote

parseQuasiquote :: Parser LispVal
parseQuasiquote = do char '`'
                     expr <- parse'
                     return $ List [Atom "quasiquote", expr]

-- Bug: this allows the unquote to appear outside of a quasiquoted list
parseUnquote :: Parser LispVal
parseUnquote = do char ','
                  expr <- parse'
                  return $ List [Atom "unquote", expr]

-- Bug: this allows unquote-splicing to appear outside of a quasiquoted list
parseUnquoteSplicing :: Parser LispVal
parseUnquoteSplicing = do string ",@"
                          expr <- parse'
                          return $ List [Atom "unquote-splicing", expr]

-- # Blocks

notArgSep :: LispVal -> Bool
notArgSep (Atom sym) = sym /= "|"
notArgSep _ = False


parseBlock :: Parser LispVal
parseBlock = do string "{"
                forms <- parseList
                char '}'
                let args = takeWhile notArgSep (pull forms)
                    body = List $ tail $ dropWhile notArgSep (pull forms)
                return $ consList (Atom "λ") (List args) (if null args then forms else body)
    where consList f s (List r) = List ([f] ++ [s] ++ r)

-- # Vector literal
-- *note: this produces a list ATM*

parseVector :: Parser LispVal
parseVector = do string "["
                 elems <- parseList
                 char ']'
                 let trans = foldify (List [(Atom "quote"), (List [])]) (pull elems)
                 return $ trans
     where foldify seed elems = foldr (\acc e -> (List [(Atom "cons"), acc, e])) seed elems

parseForms = do parsedList <- parseList
                let listOfLispVal = lispValtoList parsedList
                return $ listToArray listOfLispVal

lispValtoList :: LispVal -> [LispVal]
lispValtoList (List [a]) = [a]
lispValtoList v = [v]

listToArray :: [a] -> Array Int a
listToArray xs = listArray (0,l-1) xs
    where l = length xs