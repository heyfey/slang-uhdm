// r10svs2 ARM s6 — NON-ARRAY built-ins with no parens: which does golden treat
// as a QUERY (path element) and which as a CALL?
//   * a STRING method            s.len
//   * a QUEUE MUTATOR            q.pop_front   (legal parens-less; has a VALUE)
//   * an ENUM method             e.name
//   * an ENUM query              e.first / e.last
//   * a queue VOID mutator       q.delete      (statement position)
typedef enum {A, B, C} e_t;

class ob;
  string s;
  int    q[$];
  e_t    e;

  function int f();
    int r;
    string nm;
    e_t   ef;
    r  = s.len;         // STRING method, parens-less
    r  = r + q.pop_front;   // QUEUE MUTATOR, parens-less
    nm = e.name;        // ENUM name, parens-less
    ef = e.first;       // ENUM first, parens-less
    r  = s.len();       // POSITIVE CONTROL: same string method WITH parens
    nm = e.name();      // POSITIVE CONTROL: enum name WITH parens
    q.delete();         // void mutator, statement, parens-ful
    return r + ef;
  endfunction
endclass

module top;
  ob o;
  initial begin
    o = new();
    $display("%0d", o.f());
  end
endmodule
