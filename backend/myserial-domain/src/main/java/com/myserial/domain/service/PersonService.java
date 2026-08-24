package com.myserial.domain.service;

import com.myserial.domain.entity.Credit;
import com.myserial.domain.entity.Person;
import com.myserial.domain.entity.Show;
import com.myserial.domain.repository.CreditRepository;
import com.myserial.domain.repository.PersonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PersonService {

    private final PersonRepository personRepository;
    private final CreditRepository creditRepository;

    @Transactional(readOnly = true)
    public Person getPerson(Long id) {
        return personRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Person not found: " + id));
    }

    @Transactional(readOnly = true)
    public List<Show> getKnownFor(Long personId) {
        return creditRepository.findByPersonId(personId).stream()
                .map(Credit::getShow)
                .distinct()
                .limit(10)
                .toList();
    }
}
