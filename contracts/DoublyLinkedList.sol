contract DoublyLinkedList {

  struct Element {
    address previous;
    address next;
    bytes32 data;
  }

  uint public size;
  address public tail;
  address public head;
  mapping(address => Element) elements;

  function getData(address key) returns (bytes32){
    return elements[key].data;
  }

  function getElement(address key) constant returns (Element){
    return elements[key];
  }

  function addElement(address key, bytes32 data) returns (bool){
    Element elem = elements[key];

    if(elem.data != ""){
      return false;
    }

    elem.data = data;

    if(size == 0){
      tail = key;
      head = key;
    } else {
      // Link
      elements[head].next = key;
      elem.previous = head;
      // Set this element as the new head.
      head = key;
    }
    size++;
    return true;
  }

  function removeElement(address key) returns (bool result) {

   Element elem = elements[key];

      if(elem.data == ""){
        return false;
      }

    if(size == 1){
      tail = 0x0;
      head = 0x0;
  
    } else if (key == head){

        head = elem.previous;
        elements[head].next = 0x0;

    } else if(key == tail){
      tail = elem.next;
      elements[tail].previous = 0x0;

    } else {
      address prevElem = elem.previous;
      address nextElem = elem.next;
      elements[prevElem].next = nextElem;
      elements[nextElem].previous = prevElem;
    }
    size--;
    delete elements[key];
    return true;
  }

}
