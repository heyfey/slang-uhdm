// § memberSelParenIdxSpan184: mid-path selects (member-name anchored, controls) beside trailing ones, and a two-dimensional member select
typedef struct packed { logic [3:0] v; } e_t;
typedef struct packed { e_t [3:0] w; logic [3:0][1:0] g; } m_t;
module top;
  m_t m;
  e_t arr [4];
  logic [3:0] a;
  logic b;
  logic [1:0] c;
  int i, j;
  initial begin
    a = m.w[(i)].v;
    b = arr[(i)].v[(j)];
    c = m.g[(i)];
    b = m.g[(i)][(j)];
  end
endmodule
