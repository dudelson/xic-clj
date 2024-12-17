(ns xic.core
  (:require [cli-matic.core :refer [run-cmd]]))

(defn dispatch [opts]
  (let [positional-args (:_arguments opts)]
    (println "Got positional args: " positional-args)
    (if (:lex opts)
      (println "Got lex: " (:lex opts)))
    ;; cli-matic convention is to return 0 for success and -1 for failure
    0))

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
