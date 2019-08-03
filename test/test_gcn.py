def f():
    if i % 1000 == 0:
        mean_acc = list()
    for vf in test_feed:
        if vf[self.word_num] == 0:
            mean_acc.append(0)
        else:
            mean_acc.append(self.sess.run(self.top_accuracy[0], vf))
    print("After %d training steps, validation top 1 accuracy using average model is %g " %
          (i, sum(mean_acc) / len(mean_acc)))
    mean_acc = list()
    for vf in test_feed:
        if vf[self.word_num] == 0:
            mean_acc.append(0)
        else:
            mean_acc.append(self.sess.run(self.top_accuracy[1], vf))
    print("After %d training steps, validation top 2 accuracy using average model is %g " %
