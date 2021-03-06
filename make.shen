\\ License Note:  this code is used to generate KLambda from
\\ Shen source under the 3-clause BSD license. The code may
\\ be changed but the license attached to the generated KLambda
\\ may **not** be changed. The KLambda produced is a direct
\\ derivative of the Shen sources which are 3 clause BSD licensed.
\\ Please look at the file license.pdf for an accompanying discussion.

\\ (c) Mark Tarver 2015, all rights reserved

(do
  (systemf internal)
  (systemf receive)
  (systemf <!>)
  (systemf sterror)
  (systemf *sterror*)
  (systemf ,)
  ())

\* Previously systemf'd functions have to be reverted if compiling
   with Shen versions that still have these as system functions *\

(define unsystemf
  Sym -> (put shen shen.external-symbols
              (remove Sym (get shen shen.external-symbols))))

(do
  (map (function unsystemf) [
     command-line *argv*
     fold-righ fold-left
     filter
     for-each
     exit
     read-file-as-charlist read-char-code
     get/or value/or <-address/or <-vector/or
     dict dict? dict-count dict-> <-dict <-dict/or dict-rm
     dict-fold dict-keys dict-values
  ])
  ())

(set *sources-directory* "sources/")
(set *klambda-directory* "klambda/")

(define make ->
  (do
    (output "sources directory: ~S~%" (value *sources-directory*))
    (output "klambda directory: ~S~%" (value *klambda-directory*))
    (output "~%")
    (map
      (function make-file)
      ["core"
       "declarations"
       "load"
       "macros"
       "prolog"
       "reader"
       "sequent"
       "sys"
       "dict"
       "t-star"
       "toplevel"
       "track"
       "types"
       "writer"
       "yacc"])
    (output "~%")
    (output "compilation complete.~%")
    ()))

\* Required to avoid errors when processing functions with system names *\
(defcc shen.<name>
  X := (if (symbol? X)
           X
           (error "~A is not a legitimate function name.~%" X)))

(define make-file
  File ->
    (let _ (output "compiling ~A~%" File)
         ShenFile (make-string "~A~A.shen" (value *sources-directory*) File)
         KlFile (make-string "~A~A.kl" (value *klambda-directory*) File)
         ShenCode (read-file ShenFile)
         KlCode (map (function make-kl-code) ShenCode)
         KlString (@s (license) (list->string KlCode))
         Write (write-to-file KlFile KlString)
      KlFile))

(define make-kl-code
  [define F | Rules] -> (shen.elim-def [define F | Rules])
  [defcc F | Rules] -> (shen.elim-def [defcc F | Rules])
  Code -> Code)

(define list->string
  [] -> ""
  \* Needed for 19.2, doesn't prefix `shen` correctly *\
  [[defun shen | Args] | Body] -> (list->string [[defun shen.shen | Args] | Body])
  \* shen.fail! prints as "...", needs to be handled separately *\
  [[defun fail | _] | Y] -> (@s "(defun fail () shen.fail!)" (list->string Y))
  [X | Y] -> (@s (make-string "~R~%~%" X) (list->string Y)))

\\_________________________________________________________________________________________________
\\ Note it is an offence to tamper with this section of code.  This code is **not** under BSD.

(define license
  -> "c#34;Copyright (c) 2015, Mark Tarver

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of Mark Tarver may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Mark Tarver ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Mark Tarver BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.c#34;

")
