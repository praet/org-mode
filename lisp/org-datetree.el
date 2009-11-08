;;; org-datetree.el --- Create Date entries in a tree

;; Copyright (C) 2009 Free Software Foundation, Inc.

;; Author: Carsten Dominik <carsten at orgmode dot org>
;; Keywords: outlines, hypermedia, calendar, wp
;; Homepage: http://orgmode.org
;; Version: 6.32trans
;;
;; This file is part of GNU Emacs.
;;
;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:

;; This file contains code to create entries in a tree where the top-level
;; nodes represent years, the level 2 nodes represent the months, and the
;; level 1 entries days.

;;; Code:

(require 'org)

(defun org-datetree-find-date-create (date)
  "Find or create an entry for DATE."
  (let ((year (nth 2 date))
	(month (car date))
	(day (nth 1 date)))
    (org-datetree-find-year-create year)
    (org-datetree-find-month-create year month)
    (org-datetree-find-day-create year month day)
    (goto-char (prog1 (point) (widen)))))

(defun org-datetree-find-year-create (year)
  (let ((re "^\\*+[ \t]+\\([12][0-9][0-9][0-9]\\)[ \t\n]")
	match)
    (goto-char (point-min))
    (while (and (setq match (re-search-forward re nil t))
		(goto-char (match-beginning 1))
		(< (string-to-number (match-string 1)) year)))
    (cond
     ((not match)
      (goto-char (point-max))
      (or (bolp) (newline))
      (org-datetree-insert-line year))
     ((= (string-to-number (match-string 1)) year)
      (goto-char (point-at-bol)))
     (t
      (beginning-of-line 1)
      (org-datetree-insert-line year)))))

(defun org-datetree-find-month-create (year month)
  (org-narrow-to-subtree)
  (let ((re (format "^\\*+[ \t]+%d-\\([01][0-9]\\)[ \t\n]" year))
	match)
    (goto-char (point-min))
    (while (and (setq match (re-search-forward re nil t))
		(goto-char (match-beginning 1))
		(< (string-to-number (match-string 1)) month)))
    (cond
     ((not match)
      (goto-char (point-max))
      (or (bolp) (newline))
      (org-datetree-insert-line year month))
     ((= (string-to-number (match-string 1)) month)
      (goto-char (point-at-bol)))
     (t
      (beginning-of-line 1)
      (org-datetree-insert-line year month)))))

(defun org-datetree-find-day-create (year month day)
  (org-narrow-to-subtree)
  (let ((re (format "^\\*+[ \t]+%d-%02d-\\([01][0-9]\\)[ \t\n]" year month))
	match)
    (goto-char (point-min))
    (while (and (setq match (re-search-forward re nil t))
		(goto-char (match-beginning 1))
		(< (string-to-number (match-string 1)) day)))
    (cond
     ((not match)
      (goto-char (point-max))
      (or (bolp) (newline))
      (org-datetree-insert-line year month day))
     ((= (string-to-number (match-string 1)) day)
      (goto-char (point-at-bol)))
     (t
      (beginning-of-line 1)
      (org-datetree-insert-line year month day)))))

(defun org-datetree-insert-line (year &optional month day)
  (let ((pos (point)))
    (skip-chars-backward " \t\n")
    (delete-region (point) pos)
    (insert "\n* \n")
    (backward-char 1)
    (if month (org-do-demote))
    (if day (org-do-demote))
    (insert (format "%d" year))
    (when month
      (insert (format "-%02d" month))
      (if day
	  (insert (format "-%02d %s"
			  day (format-time-string
			       "%A" (encode-time 0 0 0 day month year))))
	(insert (format " %s"
			(format-time-string
			 "%B" (encode-time 0 0 0 1 month year))))))
    (beginning-of-line 1)))

(provide 'org-datetree)

;; arch-tag: 1daea962-fd08-448b-9f98-6e8b511b3601

;;; org-datetree.el ends here