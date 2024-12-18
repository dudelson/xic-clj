(ns build
  (:require [clojure.tools.build.api :as b]))

(def lib 'dudelson/xic)
(def version "0.1.0")
(def class-dir "build/classes")
(def uber-file (format "build/%s-%s-standalone.jar" (name lib) version))

;; delay to defer artifact downloads
(def basis (delay (b/create-basis {:project "deps.edn"})))

;; clean task lives in Justfile (I can move here if it start to make sense to do so)

(defn compile [_]
  (b/javac {:src-dirs ["java"]
            :class-dir class-dir
            :basis @basis}))

(defn uberjar [_]
  ;; we invoke the compilation step from the Justfile because
  ;; I find it simpler to reason about
  ;;(compile nil)
  ;;(b/write-pom {:class-dir class-dir
  ;;              :lib lib
  ;;              :version version
  ;;              :basis @basis
  ;;              :src-dirs ["src"])
  (b/copy-dir {:src-dirs ["src"]
               :target-dir class-dir})
  (b/compile-clj {:basis @basis
                  :ns-compile '[xic.core]
                  :class-dir class-dir})
  (b/uber {:class-dir class-dir
           :uber-file uber-file
           :basis @basis
           :main 'xic.core}))
