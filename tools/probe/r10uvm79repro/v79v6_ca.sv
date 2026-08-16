module ca_top;
  typedef struct packed { logic [3:0] f; logic [3:0] g; } st;
  st   sarr [0:3];
  st   s2   [0:3][0:1];
  logic [1:0] mi [0:3];
  logic [3:0] o1, o2, o3, o4;
  logic [1:0] k;

  assign o1 = sarr[mi[k]].f;            // n1 CONT-ASSIGN rvalue
  assign o2 = s2[mi[k]][1].g;           // n2 CONT-ASSIGN multi-dim
  always_comb o3 = sarr[mi[k]].f;       // n3 always_comb
  always @* o4 = sarr[mi[k]].g;         // n4 always @*

  st  warr [0:3];
  always_comb begin
    warr[mi[k]].f = 4'h3;               // n5 procedural lvalue
  end

  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      logic [3:0] gw;
      assign gw = sarr[mi[gi]].f;       // n6 generate cont-assign
    end
  endgenerate

  int q[$];
  int qi[4];
  int qr;
  initial begin
    foreach (qi[fi]) qr = sarr[mi[fi]].f;   // n7 foreach index var
  end
endmodule
