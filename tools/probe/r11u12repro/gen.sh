#!/usr/bin/env bash
cd /tmp/r11u12_grid
w() { mkdir -p "$1"; cat > "$1/dut.sv"; }
w g1 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam s_t C = s_t'(0);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g2 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam s_t C = s_t'(0);
endpackage
module top(input logic i, output logic o);
  import p::*;
  assign o = i;
endmodule
EOF
w g3 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam s_t C = s_t'(0);
endpackage
module top(input logic i, output logic o);
  import p::s_t;
  import p::C;
  assign o = i;
endmodule
EOF
w g4 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam int X = 35;
  localparam s_t C = s_t'(X);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g5 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam s_t C = s_t'(int'(35));
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g8 <<'EOF'
package p;
  typedef union packed { logic [32:0] a; logic [32:0] c; } u_t;
  localparam u_t C = u_t'(0);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g9 <<'EOF'
package p;
  typedef enum logic [1:0] { A, B, C2 } e_t;
  localparam e_t C = e_t'(1);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g10 <<'EOF'
package p;
  typedef logic [7:0] v_t;
  localparam v_t C = v_t'(5);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g11 <<'EOF'
package p;
  localparam int C = int'(35);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g12 <<'EOF'
package p;
  localparam int W = 8;
  localparam logic [7:0] C = (W)'(35);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g13 <<'EOF'
package p;
  typedef logic [3:0][7:0] pa_t;
  localparam pa_t C = pa_t'(35);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g14 <<'EOF'
package p;
  localparam byte C = byte'(35);
  localparam time T = time'(3);
  localparam logic L = logic'(1);
  localparam shortint S = shortint'(7);
  localparam longint LL = longint'(9);
  localparam integer IG = integer'(11);
  localparam bit BB = bit'(1);
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g15 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam s_t C = s_t'(35);
  localparam s_t D = C;
endpackage
module top(input logic i, output logic o);
  assign o = i;
endmodule
EOF
w g17 <<'EOF'
package p;
  typedef struct packed { logic [31:0] a; logic b; } s_t;
  localparam s_t C = s_t'(35);
endpackage
module top(input logic i, output logic o);
  import p::*;
  localparam s_t L = C;
  assign o = i;
endmodule
EOF
