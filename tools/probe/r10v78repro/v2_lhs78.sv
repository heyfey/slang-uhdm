// r10v78 arm v2 — the Lhs LADDER for § genCaReplWholeFold78: exactly which
// Lhs shapes Surelog's writeCont_assign can reduce at all (`lhs->UhdmType() ==
// uhdmref_obj` AND `bindVariable` non-null), measured from a GEN scope.
interface v2if;
  logic [3:0] isig;
  logic [3:0] jsig;
endinterface
module v2sub(output logic [3:0] po, inout wire [3:0] pio);
  localparam int TW = 6;
  logic [3:0]  mb_var;      // module-body var, target 4  < natural 6
  wire  [3:0]  mb_net;      // module-body NET
  logic signed [3:0] mb_sgn;
  int          mb_int;      // 32-bit 2-state
  byte         mb_byte;     // 8-bit
  bit   [3:0]  mb_bit;
  typedef enum logic [2:0] { A=0, B=1 } e_t;
  e_t          mb_enum;     // enum, 3 bits
  typedef struct packed { logic [1:0] a; logic [1:0] b; } sp_t;
  sp_t         mb_sp;       // packed struct, 4 bits
  logic [7:0]  mb_sel;      // for a part-select / bit-select Lhs
  logic [3:0]  mb_arr [0:3];// unpacked array element Lhs
  logic [1:0]  mb_c0, mb_c1;// concat Lhs
  logic [3:0]  mb_dup;      // shadowed by a gen-local of the SAME name
  if (TW > 0) begin : g2
    logic [3:0] gl_var;     // gen-LOCAL var
    wire  [3:0] gl_net;     // gen-LOCAL net
    logic [3:0] mb_dup;     // SAME NAME as the module-body signal
    assign mb_var    = {TW{1'b1}};      // L1  module-body var        (bind)
    assign mb_net    = {TW{1'b1}};      // L2  module-body net        (bind)
    assign mb_sgn    = {TW{1'b1}};      // L3  signed module-body var
    assign mb_int    = {TW{1'b1}};      // L4  int  (32)
    assign mb_byte   = {TW{1'b1}};      // L5  byte (8)
    assign mb_bit    = {TW{1'b1}};      // L6  bit [3:0]
    assign mb_enum   = e_t'({TW{1'b1}});// L7  enum Lhs via a cast
    assign mb_sp     = {TW{1'b1}};      // L8  packed struct Lhs
    assign po        = {TW{1'b1}};      // L9  a module PORT (output)
    assign pio       = {TW{1'b1}};      // L10 a module PORT (inout wire)
    assign mb_sel[3:0] = {TW{1'b1}};    // L11 a PART-SELECT Lhs
    assign mb_sel[7]   = {TW{1'b1}};    // L12 a BIT-SELECT Lhs
    assign mb_arr[1] = {TW{1'b1}};      // L13 an UNPACKED-ARRAY element Lhs
    assign {mb_c1, mb_c0} = {TW{1'b1}}; // L14 a CONCAT Lhs
    assign gl_var    = {TW{1'b1}};      // L15 a GEN-LOCAL var    (no bind?)
    assign gl_net    = {TW{1'b1}};      // L16 a GEN-LOCAL net    (no bind?)
    assign mb_dup    = {TW{1'b1}};      // L17 a gen-local SHADOWING a
                                        //     module-body name of width 4
    assign impl_g    = {TW{1'b1}};      // L18 an IMPLICIT net in the gen scope
  end
endmodule

module v2;
  logic [3:0] t_po;
  wire  [3:0] t_pio;
  v2if u_if();
  v2sub u0(.po(t_po), .pio(t_pio));
  v2sub u1(.po(), .pio());
  v2sub u2(.po(), .pio());
  localparam int TW = 6;
  if (TW > 0) begin : g3
    assign u_if.isig = {TW{1'b1}};      // L19 an INTERFACE signal Lhs
  end
endmodule
