// § tfItemInitLocalAtType209 — r11u217 l02: a TASK with a body `input` port (tf-item form) declaring initialized locals of an enum, a packed struct and a string, called from a module initial block; and a module function with a body `output`
module top (output int o);
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  int r;
  task tk;
    input int i;
    e_t e = B;
    s_t s = '{a: 2'd1, b: 1'b0};
    string n = "x";
    r = i + int'(e) + s.a + n.len();
  endtask
  function void fo;
    output int q;
    int k = 3;
    q = k;
  endfunction
  initial begin
    tk(1);
    fo(o);
  end
endmodule
