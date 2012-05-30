BALIGN
======

BALIGN is a multi-functional batch sequence alignment tool. It has been used in several bioinformatics applications by [ITU Computer Engineering Bioinformatics Group](http://www.bioinformatics.itu.edu.tr/), but its abilities are not limited to biological sequences. Any type of sequence with an ASCII representation and a scoring matrix can be handled by BALIGN. The source code contains generic aligner classes which can be used separately.

# Download
You can download BALIGN [here](https://sourceforge.net/projects/balign/). There is also an online bioinformatics toolkit including BALIGN for biological sequences [here](http://160.75.26.175/bioinfo/tools/). For example scoring matrices to be used in BALIGN, refer [here](http://sourceforge.net/projects/balign/files/dat/scoring-matrices.zip/download).

# Documentation
For detailed information on how to use BALIGN, please refer to the online [documentation](https://github.com/eseraygun/balign/wiki/Documentation).

# Citation
If you use BALIGN in your research, please cite the following article: 

* Aygün, E.; Oommen, B. & Cataltepe, Z. Peptide classification using optimal and information theoretic syntactic modeling Pattern Recognition, Elsevier, 2010

# Features
Here is an incomplete list of features that has been implemented in BALIGN so far.

## Sequence Alignment
Using BALIGN, you can compute pairwise alignments for given lists of sequences. It can perform both global and local alignment with affine gap penalties, and it can produce bit score, conservation score and percent identity matrices. For more information please see: 

* Needleman, S. & Wunsch, C. A general method applicable to the search for similarities in the amino acid sequence of two proteins J. Mol. Biol, 1970, 48, 443-453
* Smith, T. & Waterman, M. Identification of common molecular subsequences J. Mol. Bwl, 1981, 147, 195-197

## Transition Probability
Sequence transition probability computation is a fairly new and robust method of sequence comparison. It is formalized by Oommen and Kashyap in 1998 and applied to the peptide classification problem successfully by Aygün, Oommen and Cataltepe in 2009. You can use BALIGN to compute logarithmic transition probability matrices for given lists of sequences. For more information please see: 

* Oommen, B. & Kashyap, R. A formal theory for optimal and information theoretic syntactic pattern recognition Pattern Recognition, Elsevier, 1998, 31, 1159-1177
* Aygün, E.; Oommen, B. & Cataltepe, Z. Peptide classification using optimal and information theoretic syntactic modeling Pattern Recognition, Elsevier, 2010
* Aygün, E.; Oommen, B. & Cataltepe, Z. On utilizing optimal and information theoretic syntactic modeling for peptide classification Pattern Recognition in Bioinformatics, IAPR, 2009

## Compound Sequence Alignment and Compound Transition Probability
In 2000, Wallqvist et al. showed that aligning amino acid sequences along with secondary structures increases the classification performance significantly. Compound versions of alignment score and transition probability algorithms let you combine primary structure and secondary structure information in a single computation to generate more informative similarity scores. For more information please see:

* Wallqvist, A.; Fukunishi, Y.; Murphy, L.; Fadel, A. & Levy, R. Iterative sequence/secondary structure search for protein homologs: comparison with amino acid sequence alignments and application to fold recognition in genome databases. Bioinformatics, Oxford, 2000, 16, 988

# Contact
BALIGN is implemented by [Eser Aygün](http://www2.itu.edu.tr/~aygunes/ Eser Aygün).