#!/bin/bash
# ==============================================================
# organize_files.sh
# Organizes messy_folder_zip.zip by file type, detects duplicates
# (against standalone uploaded copies), and creates shortcut
# pointer files instead of duplicating data. Nothing is deleted.
# ==============================================================

set -e  # stop the script if any command fails

UPLOADS="/mnt/user-data/uploads"
WORK="/home/claude"
EXTRACT_DIR="$WORK/messy_extract"
SRC="$EXTRACT_DIR/messy_folder"
ORG="$WORK/Organized"

# --------------------------------------------------------------
# STEP 1: Extract the zip fresh (clean slate every run)
# --------------------------------------------------------------
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
unzip -o "$UPLOADS/messy_folder_zip.zip" -d "$EXTRACT_DIR"

# --------------------------------------------------------------
# STEP 2: Inspect files — sizes + hashes (for duplicate detection
# and >100MB check). This is just for reporting, not required
# for the organizing steps below.
# --------------------------------------------------------------
echo "=== File sizes ==="
find "$SRC" -type f -printf '%s\t%p\n' | sort -k2

echo "=== Files over 100MB (should be empty) ==="
find "$SRC" -type f -size +100M

echo "=== MD5 hashes (zip contents) ==="
find "$SRC" -type f -exec md5sum {} \; | sort

echo "=== MD5 hashes (standalone uploads, to cross-check duplicates) ==="
md5sum "$UPLOADS"/*.* 2>/dev/null || true

# --------------------------------------------------------------
# STEP 3: Create the type-based folder structure
# NOTE: the original version of this script used
#   mkdir -p Organized/{Documents_Word,PDFs,...}
# Brace expansion like this does NOT work in every shell —
# in the shell this ran in, it literally created one folder
# named "{Documents_Word,PDFs,...}" instead of expanding.
# Fixed by listing each folder explicitly.
# --------------------------------------------------------------
rm -rf "$ORG"
mkdir -p "$ORG/Documents_Word"
mkdir -p "$ORG/PDFs"
mkdir -p "$ORG/Web_HTML"
mkdir -p "$ORG/Notebooks_Python"
mkdir -p "$ORG/Spreadsheets_CSV"
mkdir -p "$ORG/Images"
mkdir -p "$ORG/Archives"

# --------------------------------------------------------------
# STEP 4: Copy each file into its type folder, fixing
# double-extension names along the way (.docx.pdf.docx,
# .html.html, .csv.csv, .png.png, .pdf.pdf)
# --------------------------------------------------------------

# Documents_Word
cp "$SRC/lecture 2 assignment/Task 1 Lab-report.docx.pdf.docx" \
   "$ORG/Documents_Word/Task_1_Lab_Report.docx"
cp "$SRC/lecture 7 assgnment/project-1-money-detective/Money_Detective_Report_Syeda_Hafsa_Fatima_Naqvi.docx" \
   "$ORG/Documents_Word/"

# PDFs
cp "$SRC/lecture 2 assignment/Task_3_Slide-Presentation.pdf" \
   "$ORG/PDFs/"
cp "$SRC/lecture 2 assignment/Task_3_Slide-Promptingreport.pdf.pdf" \
   "$ORG/PDFs/Task_3_Slide_Prompting_Report.pdf"
cp "$SRC/lecture 7 assgnment/project-1-money-detective/Transaction_Analysis_Report.pdf" \
   "$ORG/PDFs/"
cp "$SRC/lecture 7 assgnment/project-2-whats-my-grade/Manual_Verification_final grades.pdf" \
   "$ORG/PDFs/"
cp "$SRC/lecture 7 assgnment/project-2-whats-my-grade/grade_calculator_codeexplained.pdf" \
   "$ORG/PDFs/"
cp "$SRC/lecture 7 assgnment/project-3-books-dont-match/Books_Reconciliation_Report.pdf" \
   "$ORG/PDFs/"

# Web_HTML
cp "$SRC/lecture 2 assignment/Task 2 snake-game-report.html.html" \
   "$ORG/Web_HTML/Task_2_Snake_Game_Report.html"
cp "$SRC/lecture 2 assignment/Task 2 snake-game.html.html" \
   "$ORG/Web_HTML/Task_2_Snake_Game.html"
cp "$SRC/lecture 4 assignment/panaguide by Mr.AI App.html" \
   "$ORG/Web_HTML/"
cp "$SRC/lecture 6 assignment/hafsa-portfolio.html" \
   "$ORG/Web_HTML/"

# Notebooks_Python
cp "$SRC/lecture 7 assgnment/project-1-money-detective/python_script.ipynb" \
   "$ORG/Notebooks_Python/"
cp "$SRC/lecture 7 assgnment/project-2-whats-my-grade/pythoncode_teachergrading.ipynb" \
   "$ORG/Notebooks_Python/"
cp "$SRC/lecture 7 assgnment/project-3-books-dont-match/payment_reconciliation.py.ipynb" \
   "$ORG/Notebooks_Python/"

# Spreadsheets_CSV
cp "$SRC/lecture 7 assgnment/project-1-money-detective/transactions.csv.csv" \
   "$ORG/Spreadsheets_CSV/transactions.csv"
cp "$SRC/lecture 7 assgnment/project-3-books-dont-match/payments.csv" \
   "$ORG/Spreadsheets_CSV/"

# Images
cp "$SRC/lecture 7 assgnment/project-1-money-detective/output script.png" \
   "$ORG/Images/"
cp "$SRC/lecture 7 assgnment/project-2-whats-my-grade/output_teacher grading_script.png" \
   "$ORG/Images/"
cp "$SRC/lecture 7 assgnment/project-3-books-dont-match/output.screenshot.png.png" \
   "$ORG/Images/output_screenshot.png"

# Archives — original zip preserved untouched, nothing deleted
cp "$UPLOADS/messy_folder_zip.zip" "$ORG/Archives/"

# --------------------------------------------------------------
# STEP 5: Create shortcut pointer files for the 6 duplicates
# (standalone uploads that were byte-identical to files already
# inside the zip). No second physical copy is made — just a
# small .txt pointing to the real file's location.
# --------------------------------------------------------------
make_shortcut() {
  local folder="$1"
  local shortcut_name="$2"
  local target="$3"
  cat > "$ORG/$folder/$shortcut_name" << EOF
This is a SHORTCUT — not a real file.

This file was a duplicate (byte-for-byte identical) of another file
already organized below, so no second physical copy was created.

Real file location:
  $target

Original duplicate file name (as uploaded):
  $(basename "$shortcut_name" .shortcut.txt)
EOF
}

make_shortcut "Documents_Word" "Task_1_Lab_Report (duplicate).shortcut.txt" \
              "Documents_Word/Task_1_Lab_Report.docx"
make_shortcut "Web_HTML" "Task_2_Snake_Game_Report (duplicate).shortcut.txt" \
              "Web_HTML/Task_2_Snake_Game_Report.html"
make_shortcut "Web_HTML" "Task_2_Snake_Game (duplicate).shortcut.txt" \
              "Web_HTML/Task_2_Snake_Game.html"
make_shortcut "PDFs" "Task_3_Slide-Presentation (duplicate).shortcut.txt" \
              "PDFs/Task_3_Slide-Presentation.pdf"
make_shortcut "PDFs" "Task_3_Slide_Prompting_Report (duplicate).shortcut.txt" \
              "PDFs/Task_3_Slide_Prompting_Report.pdf"
make_shortcut "Web_HTML" "hafsa-portfolio (duplicate).shortcut.txt" \
              "Web_HTML/hafsa-portfolio.html"
make_shortcut "Web_HTML" "panaguide by Mr.AI App (duplicate).shortcut.txt" \
              "Web_HTML/panaguide by Mr.AI App.html"

# --------------------------------------------------------------
# STEP 6: Zip the organized folder for download
# --------------------------------------------------------------
cd "$WORK"
rm -f Organized_Files.zip
zip -r Organized_Files.zip Organized

mkdir -p /mnt/user-data/outputs
cp Organized_Files.zip /mnt/user-data/outputs/

echo "=== DONE — final structure ==="
find "$ORG" -type f | sort
