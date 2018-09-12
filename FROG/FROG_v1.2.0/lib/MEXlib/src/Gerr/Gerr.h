/**	\file
 *
 *	$Author: pablo $
 *	$Date: 2006-11-11 00:15:29 $
 *	$Revision: 1.1 $
 */

#ifndef _GerrH_
#define _GerrH_

#include "../Util/mexArray.h"

//! Calculate the G FROG error.
TReal Gerr(const TmexArray &Esig, const TmexArray &Esigp);

#endif //_GerrH_
