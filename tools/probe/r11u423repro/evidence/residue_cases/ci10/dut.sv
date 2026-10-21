// residue (no law landed): see README
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
module top;
  function void f(p::f_t x);
    case (x)
      p::A: x = 0;
    endcase
  endfunction
endmodule
