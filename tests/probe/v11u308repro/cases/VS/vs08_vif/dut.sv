// § elabClsNonTrailIdxUnstored308
typedef struct packed { logic [7:0] f; } e_t;
interface ifc; e_t sa[16]; logic [3:0] k; endinterface
class grid; virtual ifc vif; int i; logic [7:0] r;
  function void probe(); r = vif.sa[i + 1].f; r = vif.sa[vif.k].f; vif.sa[i].f = r; endfunction
endclass
module top; ifc u(); endmodule
