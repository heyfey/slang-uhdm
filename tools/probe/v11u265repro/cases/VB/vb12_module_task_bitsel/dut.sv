// § cloneBitSelMemberBind265 (fresh, downstream-reachable: a package function writing a member bit select called from synthesizable logic, the package imported by an importer package and the module)
package p;
  typedef struct packed { logic [7:0] byte_en; logic [7:0] data; } op_t;
  function automatic op_t setb(op_t v, int z);
    op_t r;
    r = v;
    r.byte_en[z] = 1'b1;
    return r;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [15:0] i, input logic [2:0] k, output logic [15:0] o);
  import p::*;
  assign o = setb(op_t'(i), k);
endmodule
