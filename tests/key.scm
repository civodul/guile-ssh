;;; key.scm -- Testing of Guile-SSH keys

;; Copyright (C) 2014 Artyom V. Poptsov <poptsov.artyom@gmail.com>
;;
;; This file is a part of Guile-SSH.
;;
;; Guile-SSH is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; Guile-SSH is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Guile-SSH.  If not, see <http://www.gnu.org/licenses/>.

(use-modules (srfi srfi-64)
             (ssh key))

(define %topdir (getenv "abs_top_srcdir"))
(define %rsa-private-key-file   (format #f "~a/tests/rsakey"   %topdir))
(define %dsa-private-key-file   (format #f "~a/tests/dsakey"   %topdir))
(define %ecdsa-private-key-file (format #f "~a/tests/ecdsakey" %topdir))
(define %rsa-public-key-file    (format #f "~a/tests/rsakey.pub"   %topdir))
(define %dsa-public-key-file    (format #f "~a/tests/dsakey.pub"   %topdir))
(define %ecdsa-public-key-file  (format #f "~a/tests/ecdsakey.pub" %topdir))

(test-begin "key")

(test-assert "private-key-from-file"
  (and (private-key-from-file %rsa-private-key-file)
       (private-key-from-file %dsa-private-key-file)
       (private-key-from-file %ecdsa-private-key-file)))

(test-assert "public-key-from-file"
  (and (public-key-from-file %rsa-public-key-file)
       (public-key-from-file %dsa-public-key-file)
       (public-key-from-file %ecdsa-public-key-file)))

(define *rsa-key*       (private-key-from-file %rsa-private-key-file))
(define *dsa-key*       (private-key-from-file %dsa-private-key-file))
(define *ecdsa-key*     (private-key-from-file %ecdsa-private-key-file))
(define *rsa-pub-key*   (public-key-from-file %rsa-public-key-file))
(define *dsa-pub-key*   (public-key-from-file %dsa-public-key-file))
(define *ecdsa-pub-key* (public-key-from-file %ecdsa-public-key-file))

(test-assert "key?"
  (and (not (key? "not a key"))
       (key? *rsa-key*)
       (key? *dsa-key*)
       (key? *ecdsa-key*)
       (key? *rsa-pub-key*)
       (key? *dsa-pub-key*)
       (key? *ecdsa-pub-key*)))

(test-assert "private-key?"
  (and (private-key? *rsa-key*)
       (not (private-key? *rsa-pub-key*))
       (not (private-key? "not a key"))))

(test-assert "public-key?"
  (and (public-key? *rsa-pub-key*)

       ;; XXX: Currently a SSH key that has been read from a file
       ;; has both public and private flags.
       (public-key? *rsa-key*)

       (not (public-key? "not a key"))))

(test-assert "private-key->public-key"
  (and (private-key->public-key *rsa-key*)
       (private-key->public-key *dsa-key*)
       (private-key->public-key *ecdsa-key*)))

(test-assert "get-key-type"
  (and (eq? 'rsa   (get-key-type *rsa-key*))
       (eq? 'dss   (get-key-type *dsa-key*))
       (eq? 'ecdsa (get-key-type *ecdsa-key*))))

(test-assert "public-key->string"
  (let ((rsakey-pub "AAAAB3NzaC1yc2EAAAADAQABAAABAQC+8H9j5Yt3xeqaAxXAtSbBsW0JsJegngwfLveHA0ev3ndEKruylR6CZgf6OxshTwUeBaqn7jJMf+6RRQPTcxihgtZAfdyKdPGWDtmePBnG64+uGEaP8N3KvCzlANKf5tmxS8brJlQhxKL8t+3IE8w3QmCMnCGKWprsL/ygPA9koWauUqqKvOQbZXdUEfLvZfnsE1laRyK4dwLiiM2vyGZM/2yePLP4xYu/uYdPFaukxt3DMcgrEy9zuVcU8wbkJMKM57sambvituzMVVqRdeMX9exZv32qcXlpChl4XjFClQ0lqOb8S8CNTPXm3zQ2ZJrQtUHiD54RYhlXD7X0TO6v")
        (dsakey-pub "AAAAB3NzaC1kc3MAAACBAOpnJ64w3Qo3HkCCODTPpLqPUrDLg0bxWdoae2tsXFwhBthIlCV8N0hTzOj1Qrgnx/WiuDk5qXSKOHisyqVBv8sGLOUTBy0Fdz1SobZ9+WGu5+5EiJm78MZcgtHXHu1GPuImANifbSaDJpIGKItq0V5WhpLXyQC7o0Vt70sGQboVAAAAFQDeu+6APBWXtqq2Ch+nODn7VDSIhQAAAIA5iGHYbztSq8KnWj1J/6GTvsPp1JFqZ3hFX5wlGIV4XxBdeEZnCPrhYJumM7SRjYjWMpW5eqFNs5o3d+rJPFFwDo7yW10WC3Bfpo5xRxU35xf/aFAVbm3vi/HRQvv4cFrwTLvPHgNYGYdZiHXCXPoYIh+WoKT9n3MfrBXB4hpAmwAAAIEArkWuRnbjfPVFpXrWGw6kMPVdhOZr1ghdlG5bY31y4UKUlmHvXx5YZ776dSRSMJY2u4lS73+SFgwPdkmpgGma/rZdd9gly9T7SiSr/4qXJyS8Muh203xsAU3ukRocY8lsvllKEGiCJmrUTJWmj0UYEDsbqy2k/1Yz2Q/awygyk9c=")
        (ecdsakey-pub "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHcpje/fp21KjuZFKgmKAAwHeYJ6e3ny4LwEVjZr8hOCVlBvqj7/krVqxbwZI7EcowbpYI1F8ZszS7zfUhKT3U4="))

    (and (string=? (public-key->string *rsa-pub-key*)   rsakey-pub)
         (string=? (public-key->string *dsa-pub-key*)   dsakey-pub)
         (string=? (public-key->string *ecdsa-pub-key*) ecdsakey-pub))))

(test-end "key")

(exit (= (test-runner-fail-count (test-runner-current)) 0))

;;; key.scm ends here.
