// r10earl29 GRID arm a6 — THE OVER-FIRE CONTROL.  Indices that are NOT
// concatenations, in the SAME hier_path and plain-select contexts.  Any change
// to a cell in this arm is an OVER-FIRE of the concat law and a hard finding:
// the law must move a4/a1 cells and leave every cell here byte-identical.
module a6_noconcat (
    input  logic [3:0] w,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       o6,
    output logic       o7,
    output logic       o8
);
  typedef struct packed {logic [31:0] autoexecprogbuf;} st_t;
  typedef struct packed {logic [3:0] addr;} req_t;
  st_t  q;
  req_t rq;
  logic [31:0] pbuf;
  logic [3:0]  k;
  always_comb begin
    o1 = q.autoexecprogbuf[4'd3];          // hier_path, constant index
    o2 = q.autoexecprogbuf[k];             // hier_path, simple ref index
    o3 = q.autoexecprogbuf[rq.addr];       // hier_path, HIER ref index
    o4 = q.autoexecprogbuf[k+1];           // hier_path, arithmetic index
    o5 = pbuf[4'd3];                       // plain select, constant
    o6 = pbuf[k];                          // plain select, simple ref
    o7 = pbuf[rq.addr];                    // plain select, HIER ref
    o8 = pbuf[k-1];                        // plain select, arithmetic
  end
endmodule
