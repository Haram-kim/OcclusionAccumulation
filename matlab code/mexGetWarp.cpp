#include "mex.h"
#include "matrix.h"

#define min(X,Y) ((X) < (Y) ? (X) : (Y))  
#define max(X,Y) ((X) > (Y) ? (X) : (Y)) 

void mtxProduct(const mxArray *M, double * p, double * result);
void mtxAdd(double *p1, const mxArray *p2, double * result);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	// nlhs : the number of output : 3 -> xImg, yImg, xyz_point
	// plhs : pointer of function output
	// nrhs : the number of input : 3 -> DRef, RKInv, t, K
	// prhs : pointer of function input


	const int * SizeI;
	int u, v, height, width, i;
	double z;
	SizeI = mxGetDimensions(prhs[0]);

	height = SizeI[0];
	width = SizeI[1];

	int * SizeP = new int[3]();
	double * p = new double[3]();
	double * pTrans = new double[3]();
	double * pTransProj = new double[3]();
    double * temp = new double[3]();
	SizeP[0] = height;
	SizeP[1] = width;
	SizeP[2] = 3;

	plhs[0] = mxCreateNumericArray(2, SizeI, mxDOUBLE_CLASS, mxREAL); // xImg (Dim, size, CLASS, Real,integ..) 
	plhs[1] = mxCreateNumericArray(2, SizeI, mxDOUBLE_CLASS, mxREAL); // yImg
	plhs[2] = mxCreateNumericArray(3, SizeP, mxDOUBLE_CLASS, mxREAL); // xyz_point

	for (u = 0; u < width; u++) {
		for (v = 0; v < height; v++) {
			z = mxGetPr(prhs[0])[v + u * height];
			p[0] = u * z;
			p[1] = v * z;
			p[2] = z;
            mtxProduct(prhs[1], p, temp);
			mtxAdd(temp, prhs[2],pTrans);
			if (pTrans[2] > 0 && z > 0) {
				mtxProduct(prhs[3], pTrans,pTransProj);
				mxGetPr(plhs[0])[v + u * height] = pTransProj[0] / pTransProj[2];
				mxGetPr(plhs[1])[v + u * height] = pTransProj[1] / pTransProj[2];
				for (i = 0; i < 3; i++) {
					mxGetPr(plhs[2])[v + u * height + i * (height * width)] = pTrans[i];
				}
			}
			else {
				for (i = 0; i < 3; i++) {
                    mxGetPr(plhs[0])[v + u * height] = mxGetNaN();
                    mxGetPr(plhs[1])[v + u * height] = mxGetNaN();
					mxGetPr(plhs[2])[v + u * height + i * (height * width)] = mxGetNaN();
				}
			}
		}
	}
	delete SizeP,p,pTrans,pTransProj;
}

void mtxProduct(const mxArray *M, double * p, double * result) {
	for (int j = 0; j < 3; j++) {
        result[j] = 0;
		for (int i = 0; i < 3; i++) {
			result[j] += mxGetPr(M)[j + i * 3] * p[i];
		}
	}
}

void mtxAdd(double *p1, const mxArray *p2, double * result) {
	for (int i = 0; i < 3; i++) {
		result[i] = p1[i] + mxGetPr(p2)[i];
	}
}
