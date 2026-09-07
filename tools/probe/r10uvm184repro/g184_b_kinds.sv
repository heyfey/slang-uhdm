// r10uvm184 grid ARM B — THE RECEIVER-KIND AXIS, in a wildcard-import CLONE.
// Arm A varied the ARGUMENT over one receiver kind (a string).  This arm
// varies the RECEIVER: string / queue / dynamic array / associative array /
// fixed array / class handle, over the built-in method each kind actually has,
// with a NAME argument in every case.  It is the arm that decides whether the
// law is stated over "a built-in method call" or over "a built-in STRING
// method call" — the corpus holds one counter-example (`visited.exists(succ)`
// in uvm_phase::sync) and an arm has to say which side of the line it is on.
// Names, numbers and orders are deliberately unlike the corpus'.
package Gantry184;

  class Pallet184;
    int m_load;
  endclass

  function automatic int hoist184(input int fml_k, input string fml_t);
    string  cable;        // string receiver
    int     rope[$];      // queue receiver
    int     sling[];      // dynamic-array receiver
    int     tackle[int];  // associative-array receiver
    int     boom[4];      // fixed-array receiver
    Pallet184 crate;      // class-handle receiver
    int     kink;
    int     drum;
    int     tally;

    cable = "cablewind";
    kink  = 1;
    drum  = 2;
    rope.push_back(7);
    sling = new[3];
    tackle[5] = 9;
    crate = new();

    tally  = cable.substr(1, kink).len();   // B1  string.substr, name arg
    tally += cable.getc(kink);              // B2  string.getc, name arg
    tally += rope.size() + rope[kink];      // B3  queue, NO name argument
    tally += tackle.exists(kink);           // B4  assoc.exists, name arg
    tally += sling.sum() + boom[kink];      // B5  no name argument at all
    tally += crate.m_load + drum;           // B6  no method call
    return tally;
  endfunction

  // an ASSOCIATIVE array indexed by a class handle, exactly the corpus'
  // `int visited[uvm_phase];` shape, with a foreach LOOP VARIABLE argument
  function automatic int winch184(input int fml_m);
    int       seen[Pallet184];
    Pallet184 lot[$];
    int       count;
    count = 0;
    foreach (lot[idx]) begin
      if (!seen.exists(lot[idx])) begin
        seen[lot[idx]] = 1;
        count++;
      end
    end
    return count + fml_m;
  endfunction

endpackage

// WILDCARD import — the clone path the law owns
package Stanchion184;
  import Gantry184::*;
  int seen_stanchion = 11;
  function automatic int use_stanchion();
    return hoist184(2, "pp") + winch184(3);
  endfunction
endpackage

module top184b;
  import Stanchion184::*;
  int scored;
  initial begin
    scored = use_stanchion();
    $display("%0d", scored);
  end
endmodule
