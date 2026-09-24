// r10uvm180 arm A — THE KIND GRID.
// One home package declaring a scalar typedef of every LAW-S kind plus the
// aggregate kinds the law must NOT touch, one free subroutine per kind that
// binds it in all four roles (formal, top-level local, NESTED-BLOCK local,
// EXPRESSION operand), and one wildcard-importing package that clones the lot.
// The names are deliberately unlike each other and unlike the corpus's, so an
// arm that agrees agrees for a reason.
package kx180_home;

  typedef logic signed [31:0] amber_lt;
  typedef bit          [15:0] basalt_bt;
  typedef int                 cobalt_it;
  typedef byte                dunite_yt;
  typedef shortint            emerald_st;
  typedef longint             flint_gt;
  typedef integer             garnet_nt;

  // aggregates — LAW S never copies these, so the clone must keep whatever it
  // already had; they are here as the negative half of the kind grid.
  typedef enum logic [1:0] { HOWLITE_A, HOWLITE_B } howlite_et;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } iolite_ut;

  function automatic int unsigned amber_fn(amber_lt seam);
    amber_lt keel;
    keel = seam;
    if (keel != 0) begin
      amber_lt reef;                       // depth 1: a nested-block local
      reef = keel + 1;
      keel = reef;
    end
    return int'(keel);
  endfunction

  function automatic int unsigned basalt_fn(basalt_bt seam);
    basalt_bt keel;
    keel = seam;
    for (int q = 0; q < 4; q++) begin
      basalt_bt reef;                      // depth 2: inside a loop body
      reef = keel ^ basalt_bt'(q);
      keel = reef;
    end
    return int'(keel);
  endfunction

  function automatic int unsigned cobalt_fn(cobalt_it seam);
    cobalt_it keel;
    keel = seam;
    case (keel)
      0: begin
           cobalt_it reef;
           reef = 7;
           keel = reef;
         end
      default: keel = keel - 1;
    endcase
    return int'(keel);
  endfunction

  function automatic int unsigned dunite_fn(dunite_yt seam);
    dunite_yt keel;
    keel = seam;
    while (keel > 0) begin
      dunite_yt reef;
      reef = keel - 1;
      keel = reef;
    end
    return int'(keel);
  endfunction

  function automatic int unsigned emerald_fn(emerald_st seam);
    emerald_st keel;
    keel = seam;
    begin
      emerald_st reef;
      reef = keel;
      begin
        emerald_st shoal;                  // depth 2
        shoal = reef;
        keel = shoal;
      end
    end
    return int'(keel);
  endfunction

  function automatic int unsigned flint_fn(flint_gt seam);
    flint_gt keel;
    keel = seam;
    return int'(keel);
  endfunction

  function automatic int unsigned garnet_fn(garnet_nt seam);
    garnet_nt keel;
    keel = seam;
    return int'(keel);
  endfunction

  // THE EXPRESSION ROLE: a call whose ARGUMENT is a formal of the same
  // typedef, which is where the corpus head sat (uvm_vector_to_string).
  function automatic int unsigned amber_relay(amber_lt seam);
    return amber_fn(seam);
  endfunction

  function automatic int unsigned basalt_relay(basalt_bt seam);
    if (seam[0] & 1'b1)
      return basalt_fn(seam);
    return 0;
  endfunction

  function automatic int unsigned howlite_fn(howlite_et seam);
    howlite_et keel;
    keel = seam;
    begin
      howlite_et reef;
      reef = keel;
      keel = reef;
    end
    return int'(keel);
  endfunction

  function automatic int unsigned iolite_fn(iolite_ut seam);
    iolite_ut keel;
    keel = seam;
    begin
      iolite_ut reef;
      reef = keel;
      keel = reef;
    end
    return int'(keel.hi);
  endfunction

endpackage

package kx180_clone;
  import kx180_home::*;
endpackage

module kx180_top;
  import kx180_home::*;
  amber_lt   wharf;
  basalt_bt  jetty;
  cobalt_it  quay;
  int unsigned tally;
  initial begin
    wharf = 32'sd9;
    jetty = 16'h00f0;
    quay  = 3;
    tally = amber_relay(wharf) + basalt_relay(jetty) + cobalt_fn(quay);
  end
endmodule
