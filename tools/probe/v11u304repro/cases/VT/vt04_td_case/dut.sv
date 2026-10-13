// § tfBodyTypedefForcesBegin304
package p;
  function automatic int f(int a);
    typedef int n_t;
    case (a) 0: return 1; default: return 2; endcase
  endfunction
endpackage
module top; endmodule
