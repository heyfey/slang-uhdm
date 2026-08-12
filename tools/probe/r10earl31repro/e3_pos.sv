// r10earl31 arm e3 — THE POSITION AXIS, origin held at the witness's (a
// QUALIFIED read of a package localparam in a module that does not import it),
// context held at the witness's (inside a process).  Which POSITIONS does golden
// stamp, and which does it leave bare?  This is the arm that prices how far the
// law could reach if it were written as "every qualified pkg-param fold".
//
//   p1  d[pk::DC]                bit_select INDEX
//   p2  r.data[pk::DC]           bit_select index inside a hier_path
//   p3  d[pk::DC +: 4]           indexed part select BASE
//   p4  d[0 +: pk::DC]           indexed part select WIDTH
//   p5  y = pk::DC;              assignment RHS, directly
//   p6  y = pk::DC - 1;          assignment RHS, one operation deep
//   p7  {pk::DC{1'b1}}           REPLICATION COUNT
//   p8  {pk::DC, 4'h1}           CONCAT ELEMENT
//   p9  case (x) pk::DC:         CASE ITEM
//   p10 if (x == pk::DC)         IF CONDITION
//   p11 f3(pk::DC)               FUNCTION-CALL ARGUMENT
//   p12 $clog2(pk::DC)           SYS-FUNC ARGUMENT (vo.sv row F control)
//   p13 logic [pk::DC-1:0] v;    a TYPESPEC RANGE bound (declaration)
//   p14 for (i=0;i<pk::DC;i++)   FOR-LOOP CONDITION
package pk;
  localparam logic [3:0] DC = 4'h2;
  typedef struct packed {
    logic [6:0]  addr;
    logic [31:0] data;
  } req_t;
endpackage

module e3 (
  input  logic [31:0] d,
  input  pk::req_t    r,
  input  logic [3:0]  x,
  output logic [31:0] y
);
  logic [pk::DC-1:0] v;                            // p13
  logic [31:0] a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, ac, ad;

  function automatic [31:0] f3(input logic [31:0] w);
    f3 = w;
  endfunction

  always_comb begin : blk
    a1 = 32'(d[pk::DC]);                           // p1
    a2 = 32'(r.data[pk::DC]);                       // p2
    a3 = 32'(d[pk::DC +: 4]);                      // p3
    a4 = 32'(d[0 +: pk::DC]);                      // p4
    a5 = pk::DC;                                   // p5
    a6 = pk::DC - 1;                               // p6
    a7 = {pk::DC{1'b1}};                           // p7
    a8 = 32'({pk::DC, 4'h1});                      // p8
    case (x)
      pk::DC:  a9 = 32'h1;                         // p9
      default: a9 = 32'h0;
    endcase
    if (x == pk::DC)                               // p10
      aa = 32'h1;
    else
      aa = 32'h0;
    ab = f3(pk::DC);                               // p11
    ac = $clog2(pk::DC);                           // p12
    ad = 32'b0;
    for (int i = 0; i < pk::DC; i++)               // p14
      ad = ad + 32'(i);
  end

  assign y = a1 ^ a2 ^ a3 ^ a4 ^ a5 ^ a6 ^ a7 ^ a8 ^ a9 ^ aa ^ ab ^ ac ^ ad ^ 32'(v);
endmodule
