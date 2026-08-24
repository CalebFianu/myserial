package com.myserial.api.controller;

import com.myserial.api.dto.response.PersonResponse;
import com.myserial.api.dto.response.ShowSummaryResponse;
import com.myserial.domain.entity.Person;
import com.myserial.domain.entity.Show;
import com.myserial.domain.service.PersonService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/people")
@RequiredArgsConstructor
public class PersonController extends BaseController {

    private final PersonService personService;

    @GetMapping("/{id}")
    public ResponseEntity<PersonResponse> getPerson(@PathVariable Long id) {
        Person person = personService.getPerson(id);
        List<Show> knownFor = personService.getKnownFor(id);
        List<ShowSummaryResponse> knownForResponses = knownFor.stream()
                .map(DtoMapper::toShowSummaryResponse)
                .toList();
        return ResponseEntity.ok(new PersonResponse(
                person.getId(), person.getTmdbId(), person.getName(), person.getProfilePath(),
                person.getKnownForDepartment(), person.getBiography(), knownForResponses
        ));
    }
}
