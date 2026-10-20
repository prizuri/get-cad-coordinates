(defun c:KOORD (/ ss i ent data typ p p1 p2 pts no fname f mode
                  x y z j objname)

  (vl-load-com)

  (prompt "\n======================================")
  (prompt "\n   EXPORT KOORDINAT MULTI OBJEK")
  (prompt "\n======================================")

  ;; Pilih sistem koordinat
  (initget "WCS UCS")
  (setq mode
        (getkword
          "\nGunakan koordinat [WCS/UCS] <WCS>: "
        )
  )

  (if (null mode)
    (setq mode "WCS")
  )

  ;; Seleksi bebas
  (prompt "\nPilih objek yang akan diambil koordinatnya: ")
  (setq ss (ssget))

  (if ss
    (progn

      ;; Tentukan file output
      (setq fname
            (getfiled
              "Simpan Koordinat"
              "Koordinat.csv"
              "csv"
              1
            )
      )

      (if fname
        (progn

          (setq f (open fname "w"))

          ;; Header
          (write-line "No,Object,Point,X,Y,Z" f)

          (setq i 0)
          (setq no 1)

          (repeat (sslength ss)

            (setq ent  (ssname ss i))
            (setq data (entget ent))
            (setq typ  (cdr (assoc 0 data)))

            ;; ==========================
            ;; POINT
            ;; ==========================
            (if (= typ "POINT")
              (progn
                (setq p (cdr (assoc 10 data)))

                (if (= mode "UCS")
                  (setq p (trans p 0 1))
                )

                (setq x (car p))
                (setq y (cadr p))
                (setq z (if (caddr p) (caddr p) 0.0))

                (write-line
                  (strcat
                    (itoa no) ",POINT,P"
                    (itoa no) ","
                    (rtos x 2 3) ","
                    (rtos y 2 3) ","
                    (rtos z 2 3)
                  )
                  f
                )

                (setq no (1+ no))
              )
            )

            ;; ==========================
            ;; BLOCK
            ;; ==========================
            (if (= typ "INSERT")
              (progn
                (setq p (cdr (assoc 10 data)))

                (if (= mode "UCS")
                  (setq p (trans p 0 1))
                )

                (setq x (car p))
                (setq y (cadr p))
                (setq z (if (caddr p) (caddr p) 0.0))

                (write-line
                  (strcat
                    (itoa no) ",BLOCK,P"
                    (itoa no) ","
                    (rtos x 2 3) ","
                    (rtos y 2 3) ","
                    (rtos z 2 3)
                  )
                  f
                )

                (setq no (1+ no))
              )
            )

            ;; ==========================
            ;; CIRCLE
            ;; mengambil titik pusat
            ;; ==========================
            (if (= typ "CIRCLE")
              (progn
                (setq p (cdr (assoc 10 data)))

                (if (= mode "UCS")
                  (setq p (trans p 0 1))
                )

                (setq x (car p))
                (setq y (cadr p))
                (setq z (if (caddr p) (caddr p) 0.0))

                (write-line
                  (strcat
                    (itoa no) ",CIRCLE,CENTER,"
                    (rtos x 2 3) ","
                    (rtos y 2 3) ","
                    (rtos z 2 3)
                  )
                  f
                )

                (setq no (1+ no))
              )
            )

            ;; ==========================
            ;; TEXT / MTEXT
            ;; mengambil insertion point
            ;; ==========================
            (if (or (= typ "TEXT")
                    (= typ "MTEXT"))
              (progn
                (setq p (cdr (assoc 10 data)))

                (if (= mode "UCS")
                  (setq p (trans p 0 1))
                )

                (setq x (car p))
                (setq y (cadr p))
                (setq z (if (caddr p) (caddr p) 0.0))

                (write-line
                  (strcat
                    (itoa no) ","
                    typ
                    ",INSERTION,"
                    (rtos x 2 3) ","
                    (rtos y 2 3) ","
                    (rtos z 2 3)
                  )
                  f
                )

                (setq no (1+ no))
              )
            )

            ;; ==========================
            ;; LINE
            ;; mengambil START dan END
            ;; ==========================
            (if (= typ "LINE")
              (progn

                (setq p1 (cdr (assoc 10 data)))
                (setq p2 (cdr (assoc 11 data)))

                (if (= mode "UCS")
                  (progn
                    (setq p1 (trans p1 0 1))
                    (setq p2 (trans p2 0 1))
                  )
                )

                ;; Start
                (write-line
                  (strcat
                    (itoa no) ",LINE,START,"
                    (rtos (car p1) 2 3) ","
                    (rtos (cadr p1) 2 3) ","
                    (rtos
                      (if (caddr p1) (caddr p1) 0.0)
                      2 3
                    )
                  )
                  f
                )
                (setq no (1+ no))

                ;; End
                (write-line
                  (strcat
                    (itoa no) ",LINE,END,"
                    (rtos (car p2) 2 3) ","
                    (rtos (cadr p2) 2 3) ","
                    (rtos
                      (if (caddr p2) (caddr p2) 0.0)
                      2 3
                    )
                  )
                  f
                )
                (setq no (1+ no))
              )
            )

            ;; ==========================
            ;; LWPOLYLINE
            ;; mengambil SEMUA vertex
            ;; ==========================
            (if (= typ "LWPOLYLINE")
              (progn

                (setq pts '())

                (foreach item data
                  (if (= (car item) 10)
                    (setq pts
                          (append
                            pts
                            (list (cdr item))
                          )
                    )
                  )
                )

                (setq j 1)

                (foreach p pts

                  ;; LWPOLYLINE biasanya hanya X/Y
                  (setq p
                        (list
                          (car p)
                          (cadr p)
                          0.0
                        )
                  )

                  (if (= mode "UCS")
                    (setq p (trans p 0 1))
                  )

                  (write-line
                    (strcat
                      (itoa no)
                      ",LWPOLYLINE,V"
                      (itoa j)
                      ","
                      (rtos (car p) 2 3)
                      ","
                      (rtos (cadr p) 2 3)
                      ","
                      (rtos
                        (if (caddr p)
                          (caddr p)
                          0.0
                        )
                        2 3
                      )
                    )
                    f
                  )

                  (setq no (1+ no))
                  (setq j (1+ j))
                )
              )
            )

            (setq i (1+ i))
          )

          (close f)

          (prompt "\n======================================")
          (prompt "\nEXPORT SELESAI")
          (prompt
            (strcat
              "\nJumlah koordinat : "
              (itoa (1- no))
            )
          )
          (prompt
            (strcat
              "\nFile : "
              fname
            )
          )
          (prompt "\n======================================")
        )
      )
    )
    (prompt "\nTidak ada objek yang dipilih.")
  )

  (princ)
)

(princ "\nKetik KOORD untuk export koordinat.")
(princ)