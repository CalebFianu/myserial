package com.myserial.api.controller;

import com.myserial.api.dto.response.PersonResponse;
import com.myserial.api.dto.response.ShowSummaryResponse;
import com.myserial.api.exception.NotFoundException;
import com.myserial.domain.entity.Credit;
import com.myserial.domain.entity.Person;
import com.myserial.domain.repository.CreditRepository;
import com.myserial.domain.repository.PersonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/people")
@RequiredArgsConstructor
public class PersonController extends BaseController {

    private final PersonRepository personRepository;
    private final CreditRepository creditRepository;

    @GetMapping("/{id}")
    public ResponseEntity<PersonResponse> getPerson(@PathVariable Long id) {
        Person person = personRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Person not found: " + id));
        List<Credit> credits = creditRepository.findByPersonId(id);
        List<ShowSummaryResponse> knownFor = credits.stream()
                .map(c -> DtoMapper.toShowSummaryResponse(c.getShow()))
                .distinct()
                .limit(10)
                .collect(Collectors.toList());
        PersonResponse response = new PersonResponse(
                person.getId(), person.getTmdbId(), person.getName(), person.getProfilePath(),
                person.getKnownForDepartment(), person.getBiography(), knownFor
        );
        return ResponseEntity.ok(response);
    }
}
