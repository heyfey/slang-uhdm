// § clsEnumBaseRefFullName251 (decode only: under --nobuiltin the class enum typedef is not listed, so the law is not reached)
package p;
class c;
  typedef bit[1:0] o_t;
  typedef enum o_t { A = 2'b01, B = 2'b10 } e_t;
  e_t m;
endclass
endpackage
module top; endmodule
