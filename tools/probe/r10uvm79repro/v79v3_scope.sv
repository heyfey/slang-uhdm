package pks;
  typedef struct { int f; } st;
  st  parr[4];
  int pidx[4];
  function automatic int pfn();
    int i; int r;
    r = parr[pidx[i]].f;              // g1 PACKAGE scope
    return r;
  endfunction
endpackage

interface ifc;
  typedef struct { int f; } st;
  st  varr[4];
  int vidx[4];
  int q;
  initial q = varr[vidx[0]].f;        // g2 INTERFACE scope
endinterface

module top;
  typedef struct { int f; int g; } st;
  st  marr[4];
  int midx[4];
  int j;
  initial begin
    j = marr[midx[j]].f;              // g3 MODULE scope rvalue
    marr[midx[j]].f = 1;              // g4 MODULE scope lvalue
  end
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      int gz;
      initial gz = marr[midx[gi]].f;  // g5 GENERATE scope
    end
  endgenerate
  task automatic tsk();
    j = marr[midx[j]].g;              // g6 TASK scope
  endtask
  ifc u_ifc();
endmodule
