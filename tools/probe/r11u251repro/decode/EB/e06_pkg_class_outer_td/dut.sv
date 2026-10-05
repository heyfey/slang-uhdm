// § clsEnumBaseRefFullName251 (decode only: under --nobuiltin the class enum typedef is not listed, so the law is not reached)
package p;
typedef bit[1:0] o_t;
class c;
  typedef enum o_t { A = 2'b01, B = 2'b10 } e_t;
endclass
endpackage
module top; endmodule
