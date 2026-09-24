// § aliasCloneTakesTargetFile137
// case al06: an unpacked alias of a package union typedef
package ap6;
  typedef union packed { logic [1:0] p; logic [1:0] q; } u;
  typedef u ub[2];
endpackage
module top();
  ap6::ub v;
endmodule
