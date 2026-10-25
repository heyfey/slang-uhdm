// § pkgVarEnumBaseRefName432
package A;
typedef enum {A,B,C=99} e_t;
e_t X;
endpackage
import A::*;
module top;
endmodule
