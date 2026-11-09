module specify6;

    reg d   = 1'b0;
    reg clk = 1'b0;

    sub i_sub(
        .d   (d),
        .clk (clk)
    );

    assign #5 clk = ~clk;

    initial
    begin
        #4;
        d = 1'b1;   // 4
        #3;
        d = 1'b0;   // 7
        #5;
        d = 1'b1;   // 12
        #3;
        d = 1'b0;   // 15
        #3;
        d = 1'b1;   // 18
        #6;
        d = 1'b0;   // 24
        #4;
        $finish;
    end

endmodule

module sub(
    input d,
    input clk
);

  specify
    // Setup limit 2, hold limit 3 around clk posedges at 5, 15, 25
    //      data edge  4: setup 5 - 4 = 1 < 2      Should fail at time 5
    //      data edge  7: hold  7 - 5 = 2 < 3      Should fail at time 7
    //      data edge 12: setup 15 - 12 = 3 >= 2   Should not fail
    //      data edge 15: hold  15 - 15 = 0 < 3    Should fail at time 15
    //      data edge 18: hold  18 - 15 = 3 >= 3   Should not fail
    //      data edge 24: setup 25 - 24 = 1 < 2    Should fail at time 25
    $setuphold(posedge clk, d, 2, 3);

    // As above but only data negedges at 7, 15 and 24
    //      data edge  4: posedge, ignored         Should not fail
    //      data edge  7: hold  7 - 5 = 2 < 3      Should fail at time 7
    //      data edge 15: hold  15 - 15 = 0 < 3    Should fail at time 15
    //      data edge 24: setup 25 - 24 = 1 < 2    Should fail at time 25
    $setuphold(posedge clk, negedge d, 2, 3);

    // Optional arguments are accepted and ignored
    // Data posedges at 4, 12, 18 around clk negedges at 10, 20
    //      data edge  4: setup 10 - 4 = 6 >= 4   Should not fail
    //      data edge 12: hold  12 - 10 = 2 >= 1  Should not fail
    //      data edge 18: setup 20 - 18 = 2 < 4   Should fail at time 20
    $setuphold(negedge clk, posedge d, 4, 1, notifier, , , dclk, dd);

  endspecify

endmodule
