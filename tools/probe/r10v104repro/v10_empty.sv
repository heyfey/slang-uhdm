// v104 arm V10 - macro references that expand to EMPTY or to text containing
// the whole literal run, and a separator that is a DIGIT next to digits.
`define EMP
`define ZA 11
`define ZB 1
`define K1 `"`EMP``-```ZA`"
`define K2 `"`ZA``-```EMP`"
`define K3 `"`ZB``1```ZB`"
`define K4 `"`ZA``1```ZA`"
`define K5 `"11``1``11`"
package v10_pk;
  parameter string k1 = `K1;
  parameter string k2 = `K2;
  parameter string k3 = `K3;
  parameter string k4 = `K4;
  parameter string k5 = `K5;
endpackage
module v10_top; endmodule
