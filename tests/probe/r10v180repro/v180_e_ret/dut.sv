// r10v180 arm E — FENCE 3 UNDER PRESSURE.  The return variable is excluded;
// everything else in the same clone is not.  Six shapes:
//   1 function returning the typedef, with block locals of the same typedef
//   2 function returning a DIFFERENT package typedef than its locals use
//   3 a task (no return variable at all)
//   4 a void function
//   5 a function whose return type is an enum typedef
//   6 a function returning the typedef whose body declares NOTHING
package Vane_pk;
  typedef logic [7:0] weather_t;
  typedef bit   [2:0] gustt_t;
  typedef enum logic [1:0] { CALM_v, GALE_v } squall_t;

  function automatic weather_t ret_same(weather_t seed);
    weather_t acc;
    acc = seed;
    begin
      weather_t deep;
      deep = weather_t'(acc + 1);
      acc = deep;
    end
    return acc;
  endfunction

  function automatic gustt_t ret_other(weather_t seed);
    weather_t acc;
    acc = seed;
    begin
      weather_t deep;
      deep = weather_t'(acc);
      acc = deep;
    end
    return gustt_t'(acc[2:0]);
  endfunction

  task automatic no_ret(input weather_t seed, output int unsigned o);
    weather_t acc;
    acc = seed;
    begin
      weather_t deep;
      deep = weather_t'(acc);
      o = int'(deep);
    end
  endtask

  function automatic void void_fn(input weather_t seed);
    weather_t acc;
    acc = seed;
    begin
      weather_t deep;
      deep = weather_t'(acc);
      acc = deep;
    end
  endfunction

  function automatic squall_t ret_enum(weather_t seed);
    weather_t acc;
    acc = seed;
    begin
      squall_t deep;
      deep = (acc == 0) ? CALM_v : GALE_v;
      return deep;
    end
  endfunction

  function automatic weather_t ret_bare(weather_t seed);
    return weather_t'(seed + 2);
  endfunction
endpackage
package Vane_imp;
  import Vane_pk::*;
endpackage
module Vane_top;
  import Vane_pk::*;
  weather_t w;
  int unsigned o;
  initial begin
    w = 8'h5a;
    void_fn(w);
    no_ret(w, o);
    o = o + int'(ret_same(w)) + int'(ret_other(w)) + int'(ret_enum(w)) +
        int'(ret_bare(w));
  end
endmodule
