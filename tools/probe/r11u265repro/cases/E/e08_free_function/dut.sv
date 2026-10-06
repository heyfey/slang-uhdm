// § cloneSharedAggOwnCopy265 (a package function, not a class method)
package p;
  typedef enum {OK, NOK} st_e;
  typedef struct { int a; st_e status; } op_t;
  function st_e f(st_e s1);
    begin
      op_t rw;
      rw.status = s1;
      return rw.status;
    end
  endfunction
  function void g(st_e s2);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
endmodule
