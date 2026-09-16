// v11u49 arm v17 — EVERY predefined integral member type, one struct each.
package p;
  typedef struct { logic [7:0] a; byte     m; } t_byte;
  typedef struct { logic [7:0] a; shortint m; } t_shortint;
  typedef struct { logic [7:0] a; int      m; } t_int;
  typedef struct { logic [7:0] a; longint  m; } t_longint;
  typedef struct { logic [7:0] a; integer  m; } t_integer;
  typedef struct { logic [7:0] a; bit      m; } t_bit;
  typedef struct { logic [7:0] a; logic    m; } t_logic;
  typedef struct { logic [7:0] a; reg      m; } t_reg;
  typedef struct { logic [7:0] a; time     m; } t_time;
  localparam t_byte     B  = '{a:8'd1, m:8'd1};
  localparam t_shortint S  = '{a:8'd2, m:16'd2};
  localparam t_int      I  = '{a:8'd3, m:32'd3};
  localparam t_longint  L  = '{a:8'd4, m:64'd4};
  localparam t_integer  G  = '{a:8'd5, m:32'd5};
  localparam t_bit      BT = '{a:8'd6, m:1'b1};
  localparam t_logic    LG = '{a:8'd7, m:1'b0};
  localparam t_reg      R  = '{a:8'd8, m:1'b1};
  localparam t_time     T  = '{a:8'd9, m:64'd9};
endpackage
module v17 (output logic [31:0] o);
  assign o = p::B.a+p::S.a+p::I.a+p::L.a+p::G.a+p::BT.a+p::LG.a+p::R.a+p::T.a;
endmodule
