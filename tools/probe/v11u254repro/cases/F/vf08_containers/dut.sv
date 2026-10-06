// § forInitSelectLhsBase254 (a queue element, an associative-array element, a dynamic-array element and a function's return variable member)
typedef struct packed { logic [3:0] a; } s_t;
module top(output int o);
  int q [$];
  int aa [string];
  int dyn [];
  function automatic s_t fr();
    for (fr.a = 0; fr.a < 2; fr.a++) o++;
  endfunction
  initial begin
    o = 0; q.push_back(0); dyn = new[2];
    for (q[0] = 0; q[0] < 2; q[0]++) o++;
    for (aa["k"] = 0; aa["k"] < 2; aa["k"]++) o++;
    for (dyn[1] = 0; dyn[1] < 2; dyn[1]++) o++;
    void'(fr());
  end
endmodule
