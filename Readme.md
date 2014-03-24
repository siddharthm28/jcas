Readme JCaS

I. Installation
In order to use the code for Joint Categorization and segmentation, you have to install the following toolboxes: 
_ blocks (0.1.1 or above)
_ vlfeat (0.9.18 or above)
_ maxflow-v3.01 or above (Miki Rubinstein Wrapper available on Matlab FileExchange)
_ graphAnalysisToolbox-1.0 or above 
_ GCMex wrapper for maxflow.

II. Usage

(0) Everything is parametrized in a JCaS() object. You can create one and explore the structure and the options available.

a.Image/ground truth format : 
_ Put the images in a directory
_ Put the ground truth labelings in another one, with .mat format being a matlab array of integers from 1 to the number of classes, and if it exists 0 as the void class.

b. Adding the database:
_ Add your database ine the @jcas/makedb.m file and

c. Parameters
_ All parameters can be modified in the Initialization.m file. To run the code without any further modification, just run the script.
_ You can transparently change the parameters, and the code will take care of reusing what was previously computed to save computation time/storage space.

d. Force recomputation
If you want to recompute some part of the algorithm,

e. Further modification
Most of the options are in a single file. You can add your own superpixels/unary/topdown features in the compute*.m files in @jcas dir.

III. Modes 
You can change the jcas.mode option to the following :
_ 0 = Unary only
_ 1 = Unary and pairwise
_ 2 = Unary + pairwise + linear topdown from ECCV12 paper
_ 3 = Unary + pairwise + linear topdown from ECCV + label cost
_ 4 = Unary + pairwise + linear topdown + label cost (= topdown histogram norm)
_ 5 = Unary + pairwise + label cost only
_ 6 = Unary + pairwise + intersection kernel (PAMI)
_ 7 = unary + pairwise + linear topdown + Unary on words (ECCV)
_ 8 = unary + pairwise + linear topdown + CRF on words (ECCV) (Under construction)
