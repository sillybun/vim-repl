def idf_modified_dot(tf_hash_x, tf_hash_y=None):
    inner_product = 0
    if tf_hash_y is None:
        for value in tf_hash_x.values():
            inner_product += value ** 2
        return inner_product
    for word in set(tf_hash_x.keys()).intersection(set(tf_hash_y.keys())):
        inner_product += tf_hash_x[word] * tf_hash_y[word]
    return inner_product
