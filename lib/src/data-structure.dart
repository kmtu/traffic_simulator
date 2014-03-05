part of traffic_simulator;

/**
 * A reversible [DoubleLinkedQueue]
 * 
 * Implements some methods utilizes the reversibility nature of [DoubleLinkedQueue]
 */
class ReversibleDBLQ<E> extends DoubleLinkedQueue<E> {
  /**
   * This method is similar to the [lastWhere] method inherited from [Iterable],
   * but it iterates from the last entry instead of the first entry,
   * and returns right away when it finds an entry satisfies the [test]
   */  
  lastWhereFromLast(bool test(E value), { Object orElse() }) {
    E result = null;
    bool foundMatching = false;
    DoubleLinkedQueueEntry<E> entry = lastEntry();
    while (entry != null) {
      if (test(entry.element)) return entry.element;
      entry = entry.previousEntry();
    }
    if (orElse != null) return orElse();
    throw new StateError("No matching element");
  }
  
  void forEachEntryFromLast(void f(DoubleLinkedQueueEntry<E> element)) {
    DoubleLinkedQueueEntry<E> entry = lastEntry();
    while (entry.previousEntry() != null) {
      DoubleLinkedQueueEntry<E> previousEntry = entry.previousEntry();
      f(entry);
      entry = previousEntry;
    }
  }
}

/**
 * Contains an [entry] pointing to the [DoubleLinkedQueueEntry] where it is contained
 */
abstract class Backtraceable {
  DoubleLinkedQueueEntry entry;
}

/**
 * A [ReversibleDBLQ] which accepts only [Backtraceable] element
 */
class BacktraceReversibleDBLQ<E> extends ReversibleDBLQ<E> {
  @override
  void addLast(Backtraceable value) {
    super.addLast(value);
    value.entry = lastEntry();
  }

  @override
  void addFirst(Backtraceable value) {
    super.addFirst(value);
    value.entry = firstEntry();
  }

  @override
  void add(Backtraceable value) {
    super.addLast(value);
    value.entry = lastEntry();
  }

  @override
  void addAll(Iterable<Backtraceable> iterable) {
    for (final Backtraceable value in this) {
      add(value);
    }
  }

  Backtraceable removeLast() {
    Backtraceable result = last;
    result.entry = null;
    return super.removeLast();
  }

  Backtraceable removeFirst() {
    Backtraceable result = first;
    result.entry = null;
    return super.removeFirst();
  }

  bool remove(Backtraceable o) {
    o.entry = null;
    return super.remove(o);
  }
}