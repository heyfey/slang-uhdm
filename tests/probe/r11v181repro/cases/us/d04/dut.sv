// § bareDecUnderscoreDropped181 (v11u181 break: an enum value, a struct pattern, a case range, an inside set, a function default argument)
module top(input int x, output int y);
  typedef enum int { A = 1_0, B = 2_0 } e_t;
  typedef struct packed { logic [15:0] f; logic [15:0] g; } s_t;
  s_t s;
  function automatic int f(int a = 1_1); return a; endfunction
  always_comb begin
    s = '{f: 1_0, g: 2_0};
    y = f();
    case (x) inside
      [1_0:2_0]: y = A;
      3_0, 4_0: y = B;
      default: y = x inside {5_0, [6_0:7_0]};
    endcase
  end
endmodule
