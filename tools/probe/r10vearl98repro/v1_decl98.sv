// v98 V1 -- THE DECLARATION-FACE GRID *WITH* A d1 ANCESTOR SHADOW.
// earl98's own g5 is the same grid with NO shadowing (nothing can move);
// this one puts every declaration face on the NEW code path.
typedef logic tl98_t;
typedef struct packed { logic [1:0] a; logic b; } st98_t;
module v1leaf98 (input logic clk, input logic [3:0] a, output logic o);
  if (1) begin : gen_b
    logic [3:0] q1, q2;
    logic       f_logic;      // plain logic
    logic [3:0] f_vec;        // logic vector
    logic       f_init = 1'b0;// logic with an initializer
    var logic   f_var;        // var logic
    wire        f_wire;       // a WIRE gen-local (kind Net -> law does not arm)
    reg  [3:0]  f_reg;        // reg vector
    bit         f_bit;        // bit
    int         f_int;        // int
    tl98_t      f_tdef;       // a typedef'd logic
    st98_t      f_struct;     // struct-typed
    logic [3:0] f_arr [0:1];  // unpacked array (element-select Lhs)
    assign f_logic  = (q1 == q2);
    assign f_vec    = (q1 ^ q2);
    assign f_init   = (q1 != q2);
    assign f_var    = (q1 <  q2);
    assign f_wire   = (q1 >  q2);
    assign f_reg    = (q1 & q2);
    assign f_bit    = (q1 <= q2);
    assign f_int    = (q1 >= q2);
    assign f_tdef   = (q1 === q2);
    assign f_struct = {q1[1:0], q1[2]} ^ {q2[1:0], q2[2]};
    assign f_arr[0] = (q1 | q2);
    assign o = f_logic ^ f_vec ^ f_init ^ f_var ^ f_wire ^ f_reg[0] ^ f_bit ^
               f_int[0] ^ f_tdef ^ f_struct.b ^ f_arr[0][0];
    always_ff @(posedge clk) begin q1 <= a; q2 <= q1; end
  end
endmodule

module v1_decl98 (input logic clk, input logic [3:0] a, output logic o);
  // EVERY face shadowed one module instance up, as a module-level decl.
  logic       f_logic;  logic [3:0] f_vec;   logic f_init;  logic f_var;
  wire        f_wire;   reg  [3:0]  f_reg;   bit   f_bit;   int   f_int;
  tl98_t      f_tdef;   st98_t      f_struct;
  logic [3:0] f_arr [0:1];
  assign f_logic = 1'b0; assign f_vec = 4'h0; assign f_wire = 1'b0;
  v1leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
