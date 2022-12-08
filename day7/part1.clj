(ns part1)

(require '[clojure.edn :as edn])
(use '[clojure.pprint :only [pprint]])
(require '[clojure.walk :refer [postwalk]])
(require '[clojure.string :refer [join]])

(defn eprintln [& args]
  (binding [*out* *err*]
    (apply println args)))

(defn third [x]
  (nth x 2))

(defn parse-wat-file [filename]
    (->> (slurp filename)
         (edn/read-string)))

(def statics (atom (array-map)))

;; which is just the sum of the sizes
(defn next-avail-static-index []
  (->> @statics
       (vals)
       (map :size)
       (reduce + 0)))

(defn define-static [name size value]
  (let [index (next-avail-static-index)]
    (swap! statics assoc name {:size size :value value :index index})
    index))
  

(defn do-subs-list [sexp]
  (let [cmd (first sexp)]
    (cond
          (= cmd 'defstatic!)
          (let [varname (second sexp)
                size (third sexp)
                value (nth sexp 3 "")
                index (define-static varname size value)]
            `(~'data (i32.const ~index) ~value))
          (= cmd 'static!)
          (let [varname (second sexp)
                static (get @statics varname)]
            (if (nil? static)
              (throw (ex-info (str "Unknown static: " varname)
                              {:varname varname})))
            `(~'i32.const ~(:index static)))

          :else sexp)))


(defn do-subs [s]
  (if (list? s)
      (do-subs-list s)
      s))


(def wat (parse-wat-file "part1.wat"))
(def replaced-wat (postwalk do-subs wat))


(pprint replaced-wat)
