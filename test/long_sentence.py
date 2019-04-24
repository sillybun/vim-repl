if right == len(temp_train) or len(temp_train[right][0]) != len(temp_train[left][0]):
    to_be_return.append((torch.stack(tuple(x[0] for x in temp_train[left:right])), torch.Tensor(
        list(x[1] for x in temp_train[left:right]))))
    left = right
