// v11u82 w10 -- the OTHER side of the producer's net/variable line: the
// package copy is a PLAIN VARIABLE in every row and the MODULE's own
// declaration varies by type.  A module-own type the producer files as a NET
// is reached first and golden binds the MODULE's; every other type leaves the
// package copy in front.
package pc;
  logic [7:0] m_st; logic [7:0] m_us; logic [7:0] m_un; logic [7:0] m_en;
  logic [7:0] m_in; logic [7:0] m_pa; logic [7:0] m_tv; logic [7:0] m_re;
endpackage

package ty;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
  typedef struct        { logic [3:0] a; logic [3:0] b; } su_t;
  typedef union  packed { logic [7:0] a; logic [7:0] b; } up_t;
  typedef enum logic [7:0] { E0 = 8'd0 } en_t;
  typedef logic [7:0] tv_t;
endpackage

module dut (output logic [31:0] o);
  import pc::*;
  ty::sp_t         m_st;   // module-own PACKED STRUCT
  ty::su_t         m_us;   // module-own UNPACKED STRUCT
  ty::up_t         m_un;   // module-own PACKED UNION
  ty::en_t         m_en;   // module-own ENUM
  int              m_in;   // module-own INT
  logic [1:0][7:0] m_pa;   // module-own PACKED ARRAY
  ty::tv_t         m_tv;   // module-own typedef'd vector
  real             m_re;   // module-own REAL
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] m_st; assign m_st = 32'd1;
    logic [31:0] m_us; assign m_us = 32'd2;
    logic [31:0] m_un; assign m_un = 32'd3;
    logic [31:0] m_en; assign m_en = 32'd4;
    logic [31:0] m_in; assign m_in = 32'd5;
    logic [31:0] m_pa; assign m_pa = 32'd6;
    logic [31:0] m_tv; assign m_tv = 32'd7;
    logic [31:0] m_re; assign m_re = 32'd8;
  end
  assign o = gv[0].m_st ^ gv[0].m_us ^ gv[0].m_un ^ gv[0].m_en
           ^ gv[0].m_in ^ gv[0].m_pa ^ gv[0].m_tv ^ gv[0].m_re;
endmodule
