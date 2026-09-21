// v11u82 w9 -- WHERE IS THE PRODUCER'S NET/VARIABLE LINE?  For each package
// TYPE, the module declares a NET of the same name.  If the producer files the
// package object in the NETS vector it is reached first and golden binds the
// PACKAGE's copy; if it files it in the VARIABLES vector the module's net wins.
// Golden's answer per row IS the classification.
package pc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  typedef union  packed { logic [7:0] a; logic [7:0] b; } un_t;
  typedef enum logic [7:0] { E0 = 8'd0, E1 = 8'd1 } en_t;
  typedef logic [7:0] tv_t;
  st_t          t_st;    // packed STRUCT
  un_t          t_un;    // packed UNION
  en_t          t_en;    // ENUM
  logic [1:0][7:0] t_pa; // packed ARRAY
  tv_t          t_tv;    // typedef'd logic vector
  logic [7:0]   t_lv;    // plain logic vector (the control)
  int           t_in;    // int
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  wire [15:0] t_st;
  wire [15:0] t_un;
  wire [15:0] t_en;
  wire [15:0] t_pa;
  wire [15:0] t_tv;
  wire [15:0] t_lv;
  wire [15:0] t_in;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] t_st; assign t_st = 32'd1;
    logic [31:0] t_un; assign t_un = 32'd2;
    logic [31:0] t_en; assign t_en = 32'd3;
    logic [31:0] t_pa; assign t_pa = 32'd4;
    logic [31:0] t_tv; assign t_tv = 32'd5;
    logic [31:0] t_lv; assign t_lv = 32'd6;
    logic [31:0] t_in; assign t_in = 32'd7;
  end
  assign o = gv[0].t_st ^ gv[0].t_un ^ gv[0].t_en ^ gv[0].t_pa
           ^ gv[0].t_tv ^ gv[0].t_lv ^ gv[0].t_in;
endmodule
