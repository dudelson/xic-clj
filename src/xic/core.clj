(ns xic.core
  (:require [xic.lexer.core :as lexer]
            [cli-matic.core :refer [run-cmd]])
  (:gen-class))

(defn -keep-xi-source-files [filenames]
  (filter
   (fn [filename]
     (let [xi-file? (some? (re-matches #".*\.xi$" filename))]
       (when (not xi-file?)
         (println "Ignoring input file" filename "because it is not a xi source file."))
       xi-file?))
   filenames))

(defn dispatch [opts]
  (let [source-files (-keep-xi-source-files (:_arguments opts))]
    (if (not-empty source-files)
      (if (:lex opts)
        (doseq [source-file source-files]
          (println "Writing lexer output for" source-file)
          (lexer/lex-and-write! source-file)))
      (do
        (println "Please supply one or more xi source files.")
        ;; cli-matic convention is to return 0 for success and -1 for failure
        -1))))

(def cli-configuration
  {:command     "xic"
   :description "Compiler for the Xi programming language"
   :version     "0.1.0"
   :opts        [{:option  "lex"
                  :as      "Generate output from lexical analysis."
                  :type    :with-flag}]  ;; automatically also generates --no-lex
   :runs        dispatch
   :subcommands []})

(defn -main [& args]
  (run-cmd args cli-configuration))

(comment
  (->> ["iinput1.xi" "input2.java" "input2.xi"]
       (filter
        (fn [filename]
          (let [xi-file? (some? (re-matches #".*\.xi$" filename))]
            (when (not xi-file?)
              (println "Ignoring input file" filename "because it is not a xi source file."))
            xi-file?))))
  ())
