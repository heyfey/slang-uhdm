// § cloneMemberImporterListing259 (a packed union member read, a module the last importer)
package p;
  typedef union packed { logic [7:0] path; logic [7:0] raw; } u_t;
  function automatic logic [7:0] f(input logic [7:0] x);
    u_t u;
    u.raw = x;
    return u.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module m2;
  import p::*;
endmodule
module top;
  m2 i();
endmodule
