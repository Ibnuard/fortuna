function ease_out_cubic(t) {
    return 1 - power(1 - t, 3);
}