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

module Primitives (globals) 
where
import Types
import Numerics
import Helpers
import Egal
import Eval (bind, eval, evalfuns)
import Mutants (iofuns)
import Control.Monad.Error (throwError, liftIO)
import System.IO
import Data.IORef

-- # Primitives

primitives :: [(String, [LispVal] -> ThrowsError LispVal)]
primitives = [("=:=", comparator (==)),
              ("<", comparator (<)),
              (">", comparator (>)),
              (">=", comparator (>=)),
              ("<=", comparator (<=)),
              ("&&", bool (&&)),
              ("||", bool (||)),
              ("string=?", str (==)),
              ("string<?", str (<)),
              ("string>?", str (>)),
              ("string<=?", str (<=)),
              ("string>=?", str (>=)),
              ("head", car),
              ("tail", cdr),
              ("cons", cons),
              ("cat", cat),
              ("not", unary fun_not),
              ("/=", fun_not . extricate . egal),
              ("=", egal),
              ("len", len),
              ("name", nom)] 


predicates :: [(String, [LispVal] -> ThrowsError LispVal)]
predicates = [("symbol?", unary fun_symbolp),
              ("string?", unary fun_stringp),
              ("number?", unary fun_numberp),
              ("bool?",   unary fun_boolp),
              ("list?",   unary fun_listp),
              ("empty?",  unary fun_emptyp)]


globals :: IO Env
globals = nullEnv >>= (flip bind $ map (funAs IOFunc) iofuns
                                        ++ map (funAs PrimitiveFunc) primitives
                                        ++ map (funAs PrimitiveFunc) numerics
                                        ++ map (funAs KFunc) evalfuns
                                        ++ map (funAs PrimitiveFunc) predicates)
    where funAs constructor (var, func) = (var, constructor func)


-- # not

fun_not :: LispVal -> ThrowsError LispVal
fun_not   (Bool v)         = return $ Bool (not v)
fun_not   _                = return $ Bool False

-- # predicates

fun_emptyp, fun_symbolp, fun_numberp, fun_stringp, fun_boolp, fun_listp :: LispVal -> ThrowsError LispVal
fun_listp   (List _)         = return $ Bool True
fun_listp   _                = return $ Bool False
fun_symbolp (Atom _)         = return $ Bool True
fun_symbolp _                = return $ Bool False
fun_numberp (Number _)       = return $ Bool True
fun_numberp _                = return $ Bool False
fun_stringp (String _)       = return $ Bool True
fun_stringp _                = return $ Bool False
fun_boolp   (Bool _)         = return $ Bool True
fun_boolp   _                = return $ Bool False
fun_emptyp  (List [])        = return $ Bool True
fun_emptyp  (List _)         = return $ Bool False
fun_emptyp  _                = return $ Bool False

-- # car / cdr / cons

car :: [LispVal] -> ThrowsError LispVal
car [List []] = return $ List []    -- yuck
car [List (x : _)] = return x
car [String (x : _)] = return (String [x])
car [badArg] = throwError $ TypeMismatch "pair" badArg
car badArgList = throwError $ NumArgs 1 badArgList

cdr :: [LispVal] -> ThrowsError LispVal
cdr [List []] = return $ List []    -- yuck
cdr [List (x : xs)] = return $ List xs
cdr [String (_ : xs)] = return (String xs)
cdr [badArg] = throwError $ TypeMismatch "list" badArg
cdr badArgList = throwError $ NumArgs 1 badArgList

cons :: [LispVal] -> ThrowsError LispVal
cons [x1, List []] = return $ List [x1]
cons [x, List xs] = return $ List $ x : xs
cons badArgList = throwError $ NumArgs 2 badArgList

cat :: [LispVal] -> ThrowsError LispVal
cat [List a, List []] = return $ List a
cat [List [], List b] = return $ List b
cat [List as, List bs] = return $ List (as ++ bs)
cat [List as, List bs, List cs] = return $ List (as ++ bs ++ cs)
cat badArgList = throwError $ NumArgs 2 badArgList

len :: [LispVal] -> ThrowsError LispVal
len [List []] = return $ Number 0
len [List l] = return $ Number (fromIntegral (length l))
len [badArg] = throwError $ TypeMismatch "list" badArg

nom :: [LispVal] -> ThrowsError LispVal
nom [s@(String _)] = return s
nom [Atom s] = return (String s)
nom [badArg] = throwError $ TypeMismatch "string" badArg