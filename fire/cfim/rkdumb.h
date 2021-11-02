//----------
// FIRE-CFIM $Id: rkdumb.h 2462 2018-07-26 14:39:59Z gedixon $
//----------


#ifndef RKDUMB
#define RKDUMB

void rkdumb(double vstart[], int nvar, double x1, double x2, int nstep,
	void (*derivs)(double, double [], double []));


#endif     // RKDUMB


