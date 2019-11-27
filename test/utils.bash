pv() {
    for var_name; do
        echo "variable '$var_name' is '${!var_name}'"
    done
}
